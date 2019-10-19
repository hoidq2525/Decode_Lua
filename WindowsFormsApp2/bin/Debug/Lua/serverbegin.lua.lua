g_request = ""
local flag_image = {
  [1] = SHARED("$image/giftaward/huo.png|18,15,32,32"),
  [2] = SHARED("$image/giftaward/jian.png|18,15,32,32"),
  [3] = SHARED("$image/giftaward/xin.png|18,15,32,32")
}
local COLOR_BLUE = ui.make_color(SHARED("16bfe9"))
local COLOR_GREEN = ui.make_color(SHARED("00ae42"))
local COLOR_GRAY = ui.make_color(SHARED("b3b3b3"))
local COLOR_YELLOW = ui.make_color(SHARED("e6c114"))
local COLOR_RED = ui.make_color(SHARED("ff0000"))
local COLOR_WHITE = ui.make_color(SHARED("ffffff"))
local g_item_mark = 0
local ITEM_MARK_QQVIP = 1
local ITEM_MARK_BLUE = 2
local qq_vip_card_item = {
  [1] = {
    [bo2.eSex_Male] = {41179, 41180},
    [bo2.eSex_Female] = {42206, 42207}
  },
  [5] = {
    53305,
    53232,
    61389
  }
}
local qq_blue_card_item = {
  [1] = {
    [bo2.eSex_Male] = {41177, 41178},
    [bo2.eSex_Female] = {42204, 42205}
  },
  [5] = {
    53305,
    53231,
    61389
  }
}
local flag_color = {
  [0] = COLOR_WHITE,
  [1] = COLOR_RED,
  [2] = COLOR_GREEN,
  [3] = COLOR_YELLOW
}
cd_view_text = ""
local get_cooldown = function(t)
  t = math.floor(t / 1000)
  local h = math.floor(t / 3600)
  local i = math.fmod(t, 3600)
  local m = math.floor(i / 60)
  local s = math.floor(math.fmod(i, 60))
  return sys.format("%02d:%02d:%02d", h, m, s)
end
function check_cooldwon(cd)
  if cd.size == 0 then
    return true
  end
  for i = 0, cd.size - 1 do
    if not bo2.is_cooldown_over(cd[i]) then
      local rt = bo2.get_cooldown_remain_time(cd[i])
      cd_view_text = get_cooldown(rt)
      return false
    end
  end
  return true
end
function check_premise(premise)
  if premise.size == 0 then
    return true
  end
  if sys.check(bo2.player) == false then
    return false
  end
  for i = 0, premise.size - 1 do
    local n = bo2.gv_gift_award:find(premise[i])
    if bo2.player:get_flag_bit(n.flag_id) ~= 1 then
      return false
    end
  end
  return true
end
local get_local_campaign_id = function(id)
  for i = 0, bo2.gv_campaign_list.size - 1 do
    local n = bo2.gv_campaign_list:get(i)
    if n.serverid == id then
      return n.id
    end
  end
  return 0
end
function check_campaign(campaign)
  if campaign.size == 0 then
    return true
  end
  for i = 0, campaign.size - 1 do
    local id = get_local_campaign_id(campaign[i])
    local s = bo2.worldevent_getstate_byid(id)
    if s == -1 or s == 1 then
      return false
    end
  end
  return true
end
function check_level(max, min)
  if bo2.player == nil then
    return false
  end
  local level = bo2.player:get_atb(bo2.eAtb_Level)
  local v = sys.variant()
  v:set(L("level"), level)
  if min ~= 0 and min > level then
    v:set(L("need"), min)
    local txt = sys.mtf_merge(v, ui.get_text("gift_award|need_level"))
    g_request = g_request .. txt .. "\n"
    return false
  elseif max ~= 0 and max < level then
    v:set(L("need"), max)
    local txt = sys.mtf_merge(v, ui.get_text("gift_award|need_level"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  return true
end
function check_item(items)
  local rst = true
  local excel_id = items[0]
  local count = items[1]
  local cur = ui.item_get_count(excel_id, true)
  if count > cur then
    local v = sys.variant()
    v:set(L("item"), excel_id)
    v:set(L("count"), cur)
    v:set(L("need"), count)
    local txt = sys.mtf_merge(v, ui.get_text("gift_award|need_item"))
    g_request = g_request .. txt .. "\n"
    rst = false
  end
  return rst
end
function check_totaltime(max, min)
  if bo2.player == nil then
    return false
  end
  local t = bo2.player:get_flag_objmem(bo2.eFlagObjMemory_TempLoginTime)
  local o = ui_main.get_os_time() - t
  local v = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_OLTotalTime) + o
  v = v - 60
  if v < 0 then
    v = 0
  end
  local arg = sys.variant()
  arg:set(L("time"), math.floor(v / 3600))
  if min ~= 0 and min > v then
    arg:set(L("need"), math.floor(min / 3600))
    local txt = sys.mtf_merge(arg, ui.get_text("gift_award|need_online"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  if max ~= 0 and max < v then
    arg:set(L("need"), math.floor(max / 3600))
    local txt = sys.mtf_merge(arg, ui.get_text("gift_award|need_online"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  return true
end
function check_create_player(max, min)
  if bo2.player == nil then
    return false
  end
  local create_time = bo2.player:get_flag_objmem(bo2.eFlagObjMemory_CreatePlayerTime)
  if create_time == 0 then
    return false
  end
  local cur_time = ui_main.get_os_time()
  local days = math.floor((cur_time - create_time) / 86400)
  local arg = sys.variant()
  arg:set(L("time"), days)
  arg:set(L("create"), os.date("%c", create_time))
  if min ~= 0 and min > days then
    arg:set(L("need"), min)
    local txt = sys.mtf_merge(arg, ui.get_text("gift_award|need_create"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  if max ~= 0 and max < days then
    arg:set(L("need"), max)
    local txt = sys.mtf_merge(arg, ui.get_text("gift_award|need_create"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  return true
end
function check_login_enclises(max, min)
  if bo2.player == nil then
    return false
  end
  local v = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_CheckInEnclises)
  local end_time = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_CheckInEndTime)
  local arg = sys.variant()
  arg:set(L("time"), v)
  arg:set(L("end"), os.date("%c", end_time))
  if min ~= 0 and min > v then
    arg:set(L("need"), min)
    local txt = sys.mtf_merge(arg, ui.get_text("gift_award|need_login_enclises"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  if max ~= 0 and max < v then
    arg:set(L("need"), max)
    local txt = sys.mtf_merge(arg, ui.get_text("gift_award|need_login_enclises"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  return true
end
function check_login_max(max, min)
  if bo2.player == nil then
    return false
  end
  local v = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_CheckInMonth)
  local end_time = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_CheckInEndTime)
  local arg = sys.variant()
  arg:set(L("time"), v)
  arg:set(L("end"), os.date("%c", end_time))
  if min ~= 0 and min > v then
    arg:set(L("need"), min)
    local txt = sys.mtf_merge(arg, ui.get_text("gift_award|need_login_inmonth"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  if max ~= 0 and max < v then
    arg:set(L("need"), min)
    local txt = sys.mtf_merge(arg, ui.get_text("gift_award|need_login_inmonth"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  return true
end
function check_qqvip(max, min)
  if bo2.player == nil then
    return false
  end
  local vip = bo2.player:get_player_dwordtemp(bo2.ePFlagDwordTemp_QQVIP)
  local v = sys.variant()
  v:set(L("vip"), vip)
  if min ~= 0 and min > vip then
    v:set(L("need"), min)
    local txt = sys.mtf_merge(v, ui.get_text("gift_award|need_vip"))
    g_request = g_request .. txt .. "\n"
    return false
  elseif max ~= 0 and max < vip then
    v:set(L("need"), max)
    local txt = sys.mtf_merge(v, ui.get_text("gift_award|need_vip"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  return true
end
function check_bluediamond(max, min)
  if bo2.player == nil then
    return false
  end
  local bluediamond = bo2.player:get_player_dwordtemp(bo2.ePFlagDwordTemp_BlueDiamond)
  local v = sys.variant()
  v:set(L("bluediamond"), bluediamond)
  if min ~= 0 and min > bluediamond then
    v:set(L("need"), min)
    local txt = sys.mtf_merge(v, ui.get_text("gift_award|need_bluediamond"))
    g_request = g_request .. txt .. "\n"
    return false
  elseif max ~= 0 and max < bluediamond then
    v:set(L("need"), max)
    local txt = sys.mtf_merge(v, ui.get_text("gift_award|need_bluediamond"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  return true
end
function check_rmbvip_level(max, min)
  if bo2.player == nil then
    return false
  end
  if bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_RMBPrivilegeHours) <= 0 then
    local txt = ui.get_text("gift_award|need_rmbvip1")
    return false
  end
  local vip = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_RMBPrivilege)
  local v = sys.variant()
  v:set(L("vip"), vip)
  if min ~= 0 and min > vip then
    v:set(L("need"), min)
    local txt = sys.mtf_merge(v, ui.get_text("gift_award|need_rmbvip"))
    g_request = g_request .. txt .. "\n"
    return false
  elseif max ~= 0 and max < vip then
    v:set(L("need"), max)
    local txt = sys.mtf_merge(v, ui.get_text("gift_award|need_rmbvip"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  return true
end
function check_first_buyrmb(max, min)
  if bo2.player == nil then
    return false
  end
  local vip = bo2.player:get_flag_bit(bo2.ePlayerFlagBit_FirstBuyRMB)
  local v = sys.variant()
  v:set(L("vip"), vip)
  if min ~= 0 and min > vip then
    v:set(L("need"), min)
    local txt = sys.mtf_merge(v, ui.get_text("gift_award|need_first_buyrmb"))
    g_request = g_request .. txt .. "\n"
    return false
  elseif max ~= 0 and max < vip then
    v:set(L("need"), max)
    local txt = sys.mtf_merge(v, ui.get_text("gift_award|need_first_buyrmb"))
    g_request = g_request .. txt .. "\n"
    return false
  end
  return true
end
function check_other(type, max, min)
  if type.size == 0 then
    return true
  end
  local rst = true
  for i = 0, type.size - 1 do
    local e = type[i]
    if e == bo2.eGiftAwardCheckType_Level then
      rst = rst and check_level(max[i], min[i])
    elseif e == bo2.eGiftAwardCheckType_TotalTime then
      rst = rst and check_totaltime(max[i], min[i])
    elseif e == bo2.eGiftAwardCheckType_CreatePlayer then
      rst = rst and check_create_player(max[i], min[i])
    elseif e == bo2.eGiftAwardCheckType_LoginEnclises then
      rst = rst and check_login_enclises(max[i], min[i])
    elseif e == bo2.eGiftAwardCheckType_LoginMax then
      rst = rst and check_login_max(max[i], min[i])
    elseif e == bo2.eGiftAwardCheckType_QQVIP then
      local tmp = check_qqvip(max[i], min[i])
      if tmp == false then
        g_item_mark = ITEM_MARK_QQVIP
      end
      rst = rst and tmp
    elseif e == bo2.eGiftAwardCheckType_BlueDiamond then
      local tmp = check_bluediamond(max[i], min[i])
      if tmp == false then
        g_item_mark = ITEM_MARK_BLUE
      end
      rst = rst and tmp
    elseif e == bo2.eGiftAwardCheckType_RmbVIPLevel then
      rst = rst and check_rmbvip_level(max[i], min[i])
    elseif e == bo2.eGiftAwardCheckType_FirestBuyRmb and rst then
      rst = check_first_buyrmb(max[i], min[i])
    end
  end
  return rst
end
function get_cur_gift(owner)
  if owner.gift.size == 0 then
    return nil
  end
  if sys.check(bo2.player) == false then
    return nil
  end
  local n
  for i = 0, owner.gift.size - 1 do
    n = bo2.gv_gift_award:find(owner.gift[i])
    if bo2.player:get_flag_bit(n.flag_id) == 0 then
      break
    end
  end
  return n
end
function get_item_flag(item)
  if bo2.player == nil then
    return 0
  end
  local owner = bo2.gv_gift_award_owner:find(item.svar.id)
  local n = get_cur_gift(owner)
  if n == nil then
    return 0
  else
    return bo2.player:get_flag_bit(n.flag_id)
  end
end
function check_on_visible(n)
  if n == nil or n.mail_id == 0 then
    return false
  end
  if check_cooldwon(n.cooldown) == false then
    return false
  end
  if check_premise(n.premise_id) == false then
    return false
  end
  if check_campaign(n.campaign_id) == false then
    return false
  end
  if check_other(n.check_type, n.check_max, n.check_min) == false then
    return false
  end
  if check_item(n.items) == false then
    return false
  end
  return true
end
function on_flag_chg()
  on_item_select(g_svrbeg_list.item_sel, true)
  on_visible(w_win, w_win.visible)
end
function check_qq_item_btn()
end
function on_qq_item_select(item, sel)
  local item_type = ""
  local card_item = {}
  local check_line = {}
  local check_fn
  local luck_cd = 0
  local flag_id = 0
  if item.svar.qq_type == 1 then
    qq_right:search("open_btn").text = ui.get_text("about_qq|open_vip")
    item_type = "vip"
    card_item = qq_vip_card_item
    g_item_mark = ITEM_MARK_QQVIP
    check_line = {
      48,
      51,
      0,
      0,
      50
    }
    check_fn = check_qqvip
    luck_cd = 50079
    flag_id = bo2.ePFlagDwordTemp_QQVIP
  elseif item.svar.qq_type == 2 then
    qq_right:search("open_btn").text = ui.get_text("about_qq|open_blue")
    item_type = "blue"
    card_item = qq_blue_card_item
    g_item_mark = ITEM_MARK_BLUE
    check_line = {
      52,
      55,
      0,
      0,
      54
    }
    check_fn = check_bluediamond
    luck_cd = 50080
    flag_id = bo2.ePFlagDwordTemp_BlueDiamond
  end
  local sex = bo2.player:get_atb(bo2.eAtb_Sex)
  if sex == bo2.eSex_Female then
    check_line[1] = check_line[1] + 1
  end
  for i = 1, 5 do
    local item_name = "qq_item" .. i
    local qq_item = qq_right:search(item_name)
    qq_item:search("qq_text").text = ui.get_text("about_qq|qq_" .. item_type .. "_award" .. i)
    local card_panel = qq_item:search("card_panel")
    if i == 1 then
      card_panel:search("card1").excel_id = card_item[1][sex][1]
      card_panel:search("card2").excel_id = card_item[1][sex][2]
    elseif i == 5 then
      card_panel:search("card1").excel_id = card_item[5][1]
      card_panel:search("card2").excel_id = card_item[5][2]
      card_panel:search("card3").excel_id = card_item[5][3]
    end
    local btn = qq_item:search("btn")
    btn.enable = true
    if i == 3 then
      btn.text = ui.get_text("about_qq|btn_luck")
      if check_fn(1, 0) == false then
        btn.text = ui.get_text("about_qq|btn_txt_novip")
        btn.enable = false
      elseif bo2.is_cooldown_over(luck_cd) == false then
        btn.text = ui.get_text("about_qq|btn_txt_cooldown")
        btn.enable = false
      end
    elseif check_line[i] ~= 0 then
      local n = bo2.gv_gift_award:find(check_line[i])
      if i == 2 then
        btn.text = ui.get_text("about_qq|btn_get_title")
      else
        btn.text = ui.get_text("about_qq|btn_get_gift")
      end
      if check_fn(1, 0) == false then
        btn.enable = false
        btn.text = ui.get_text("about_qq|btn_txt_novip")
      elseif check_cooldwon(n.cooldown) == false then
        btn.enable = false
        btn.text = ui.get_text("about_qq|btn_txt_cooldown")
      elseif check_campaign(n.campaign_id) == false then
        btn.enable = false
      end
    end
    if bo2.player:get_player_dwordtemp(flag_id) == 0 then
      btn.enable = false
    end
  end
end
function on_item_select(item, sel)
  item:search("fig_highlight").visible = sel
  item:search("fig_highlight_sel").visible = sel
  if item.svar.qq_style == true and qq_right ~= nil then
    qq_right.visible = sel
    cmn_right.visible = not sel
    g_award_fig.visible = not sel
    on_qq_item_select(item, sel)
    return
  else
    cmn_right.visible = sel
    qq_right.visible = not sel
  end
  g_request = ""
  g_desc_need.mtf = ""
  g_gift_cdview.text = ""
  g_award_panel.visible = false
  g_award_fig.visible = false
  g_btn.enable = true
  g_btn.text = ui.get_text(L("gift_award|get_btn"))
  g_item_mark = 0
  local owner = bo2.gv_gift_award_owner:find(item.svar.id)
  local n = get_cur_gift(owner)
  if not sel then
    if n ~= nil and n.flag_id ~= 0 and bo2.player then
      bo2.player:remove_on_flagmsg(bo2.eFlagType_Bit, n.flag_id, "ui_guild_mod.ui_guild.on_flag_chg")
    end
    return
  end
  g_time_box.mtf = owner.time
  g_desc_box.mtf = owner.desc
  if n == nil then
    return
  end
  if n.mail_id == 0 then
    return
  end
  g_award_panel.visible = true
  g_award_fig.visible = true
  local mail = bo2.gv_mail_list:find(n.mail_id)
  if not mail.item.empty then
    for i, v in string.gmatch(tostring(mail.item), "(%w+)*(%w+)") do
      g_item_view.excel_id = i
    end
  end
  g_gift_name.text = n.name
  g_request_box.mtf = n.desc
  local comp = 0
  if bo2.player then
    comp = bo2.player:get_flag_bit(n.flag_id)
  end
  if comp == 1 then
    g_btn.text = ui.get_text(L("gift_award|get_btn_over"))
    g_btn.enable = false
  else
    if check_cooldwon(n.cooldown) == false then
      g_gift_cdview.text = cd_view_text
      g_btn.text = ui.get_text(L("gift_award|cooldown"))
      g_btn.enable = false
    end
    if check_premise(n.premise_id) == false then
      g_btn.enable = false
    end
    if check_campaign(n.campaign_id) == false then
      g_btn.enable = false
    end
    if check_other(n.check_type, n.check_max, n.check_min) == false then
      g_btn.enable = false
    end
    if check_item(n.items) == false then
      g_btn.enable = false
    end
  end
  g_desc_need.mtf = g_request
  if n.flag_id ~= 0 and bo2.player then
    bo2.player:insert_on_flagmsg(bo2.eFlagType_Bit, n.flag_id, on_flag_chg, "ui_guild_mod.ui_guild.on_flag_chg")
  end
end
function on_visible(w, v)
  if bo2.player == nil then
    return
  end
  local gift_count = 0
  for i = 0, g_svrbeg_list.item_count - 1 do
    local item = g_svrbeg_list:item_get(i)
    if item.svar.qq_style == false then
      local owner = bo2.gv_gift_award_owner:find(item.svar.id)
      local n = get_cur_gift(owner)
      local flag_v = get_item_flag(item)
      if n ~= nil then
        item.svar.tmep_id = n.id
      end
      if n ~= nil and check_campaign(n.campaign_id) == false then
        item.visible = false
      else
        item.visible = true
      end
      if check_on_visible(n) == true and flag_v == 0 then
        gift_count = gift_count + 1
        item:search("highlight").visible = true
      else
        item:search("highlight").visible = false
      end
      if n == nil or n.mail_id == 0 then
        item.svar.sort_id = 3
        item:search("name").color = COLOR_BLUE
      elseif flag_v == 1 then
        item.svar.sort_id = 4
        item:search("name").color = COLOR_GRAY
      else
        item.svar.sort_id = 1
        item:search("name").color = COLOR_BLUE
      end
    else
      item.svar.sort_id = 1
      item.svar.tmep_id = 0
      item:search("name").color = COLOR_BLUE
    end
  end
  local fn = function(a, b)
    if a.svar.sort_id < b.svar.sort_id then
      return -1
    elseif a.svar.sort_id == b.svar.sort_id then
      if a.svar.tmep_id < b.svar.tmep_id then
        return -1
      else
        return 1
      end
    else
      return 1
    end
  end
  g_svrbeg_list:item_sort(fn)
  if g_svrbeg_list.item_count ~= 0 and g_svrbeg_list.item_sel == nil then
    item = g_svrbeg_list:item_get(0)
    item.selected = true
    on_item_select(item, true)
  end
  ui_gift_award.g_cur_gifts[w_win.name] = gift_count
  ui_gift_award.flicker_visible()
end
function on_init()
  if bo2.gv_gift_award.size == 0 then
    return
  end
  local item_file = "$frame/giftaward/serverbegin.xml"
  local item_style = "item"
  local my_type = 0
  if w_win.name == L("serverbegin_main") then
    my_type = 1
  elseif w_win.name == L("serverbegin_main1") then
    my_type = 2
  else
    my_type = 3
  end
  for i = 0, bo2.gv_gift_award_owner.size - 1 do
    local n = bo2.gv_gift_award_owner:get(i)
    if n.type ~= 0 and n.type == my_type then
      local item = g_svrbeg_list:item_append()
      item:load_style(item_file, item_style)
      item.svar.show_text = false
      item.svar.qq_style = false
      item.svar.gift_id = 0
      item.svar.id = n.id
      item:search("name").text = n.name
      local flag = item:search("flag")
      flag.image = flag_image[n.flag]
      item.svar.flag = n.flag
    end
  end
  if my_type == 3 then
    local qq_type_rand = bo2.rand(1, 2)
    local qq_item_sel = {}
    for i = 1, 2 do
      local item = g_svrbeg_list:item_append()
      item:load_style(item_file, item_style)
      item.svar.show_text = false
      item.svar.qq_style = true
      item.svar.gift_id = 0
      item.svar.id = 0
      item.svar.qq_type = qq_type_rand
      item:search("name").text = ui.get_text("about_qq|qq_item" .. qq_type_rand)
      if qq_type_rand == 1 then
        qq_type_rand = 2
      else
        qq_type_rand = 1
      end
      local flag = item:search("flag")
      flag.image = flag_image[3]
      item.svar.flag = 3
      table.insert(qq_item_sel, item)
    end
  end
  if g_svrbeg_list.item_count == 0 then
    local btn = ui_widget.ui_tab.get_button(ui_gift_award.w_win, w_win.name)
    btn.visible = false
  end
end
function on_btn_click(btn)
  local item = g_svrbeg_list.item_sel
  local owner = bo2.gv_gift_award_owner:find(item.svar.id)
  local n = get_cur_gift(owner)
  local v = sys.variant()
  v:set(packet.key.cmn_id, n.id)
  bo2.send_variant(packet.eCTS_GiftAward_Get, v)
end
local check_all = function()
  g_request = ""
  local gift_count = 0
  for i = 0, g_svrbeg_list.item_count - 1 do
    local item = g_svrbeg_list:item_get(i)
    if item.svar.qq_style == false then
      local owner = bo2.gv_gift_award_owner:find(item.svar.id)
      local n = get_cur_gift(owner)
      if n ~= nil and n.mail_id ~= 0 then
        if n.id ~= item.svar.gift_id then
          item.svar.gift_id = n.id
          if item.svar.show_text == true then
            item.svar.show_text = false
          end
        end
        if check_on_visible(n) == true and bo2.player:get_flag_bit(n.flag_id) == 0 then
          gift_count = gift_count + 1
          if item.svar.show_text == false then
            local arg = sys.variant()
            arg:set(L("name"), n.name)
            ui_chat.show_ui_text_id(73186, {
              name = n.name
            })
            item.svar.show_text = true
          end
        end
      end
    end
  end
  ui_gift_award.g_cur_gifts[w_win.name] = gift_count
end
function on_timer()
  check_all()
end
function on_topbtn_click(btn)
  if g_item_mark == 0 then
    return
  end
  local uri = "http://d2.qq.com/comm-htdocs/pay/client/dj2/"
  local style = ""
  local title = ""
  local pixel_size
  if g_item_mark == ITEM_MARK_QQVIP then
    uri = "http://youxi.vip.qq.com/pay/pay.html#"
    style = "vip_ie"
    title = ui.get_text("about_qq|buyrmb_vip")
    pixel_size = ui.point(590, 440)
  elseif g_item_mark == ITEM_MARK_BLUE then
    uri = "http://gamevip.qq.com/lz_pop_15/pay_pop_all.html?version=v2.0&refer=LZ.ACT.DJ2YXN&ADTAG=LZ.ACT.DJ2YXN&appId=10420&ht=normal&obj=my&ft=all&time=1&pm=qdqb&ian=on"
    style = "blue_ie"
    title = ui.get_text("about_qq|buyrmb_blue")
    pixel_size = ui.point(498, 416)
  end
  local cfg = bo2.get_config()
  local wnd = cfg:get("fullscreen").v_int
  if wnd == 1 then
    ui.shell_execute("open", uri)
    return
  end
  local parent = ui_gift_award.w_rmbMain:search("iewrap")
  parent:control_clear()
  local c = ui.create_control(parent, "wnd_html_view")
  c:load_style("$frame/giftaward/giftaward.xml", style)
  local vis = not ui_gift_award.w_rmbMain.visible
  if btn.name == L("r") then
    vis = true
  end
  ui_gift_award.w_rmbMain.visible = vis
  ui_gift_award.w_http_win_title.text = title
  c.pixel_size = pixel_size
  ui_gift_award.w_rmbMain.size = ui.point(c.size.x + 14, c.size.y + 40)
end
function update_rmb_window()
  if not ui_gift_award.w_rmbMain.visible then
    return
  end
  local ie_wnd = ui_gift_award.w_rmbMain:search("ie_wnd")
  if ie_wnd == nil then
    return
  end
  ie_wnd.pixel_size = ui.point(590, 416)
  local s = ie_wnd.size
  ui_gift_award.w_rmbMain.size = ui.point(s.x + 14, s.y + 40)
end
function reset_sel()
  on_item_select(g_svrbeg_list.item_sel, true)
end
function on_qqbtn1_click(btn)
  local id = 0
  if g_item_mark == ITEM_MARK_QQVIP then
    id = 48
  elseif g_item_mark == ITEM_MARK_BLUE then
    id = 52
  end
  if bo2.player:get_atb(bo2.eAtb_Sex) == bo2.eSex_Female then
    id = id + 1
  end
  local v = sys.variant()
  v:set(packet.key.cmn_id, id)
  bo2.send_variant(packet.eCTS_GiftAward_Get, v)
  bo2.AddTimeEvent(10, reset_sel)
end
function on_qqbtn2_click(btn)
  local id = 0
  if g_item_mark == ITEM_MARK_QQVIP then
    id = 51
  elseif g_item_mark == ITEM_MARK_BLUE then
    id = 55
  end
  local v = sys.variant()
  v:set(packet.key.cmn_id, id)
  bo2.send_variant(packet.eCTS_GiftAward_Get, v)
  bo2.AddTimeEvent(10, reset_sel)
end
function on_qqbtn3_click(btn)
  ui_supermarket2.clickOpenDiscount()
end
function on_qqbtn5_click(btn)
  local id = 0
  if g_item_mark == ITEM_MARK_QQVIP then
    id = 50
  elseif g_item_mark == ITEM_MARK_BLUE then
    id = 54
  end
  local v = sys.variant()
  v:set(packet.key.cmn_id, id)
  bo2.send_variant(packet.eCTS_GiftAward_Get, v)
  bo2.AddTimeEvent(10, reset_sel)
end
