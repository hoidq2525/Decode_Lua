local g_broadcast_text = {}
local g_cur_broadcast_idx = 0
local g_max_broadcast_idx = 0
local c_box_x = 672
local g_all_item = {}
local g_cur_item = {}
local g_down_card = {}
local g_page_cur = 0
local g_page_max = 0
local g_daily_btn = {}
local g_daily_can_give_idx = 1
local btn_image = {
  [1] = SHARED("$image/giftaward/btn_qq.png|0,15,32,256"),
  [2] = SHARED("$image/giftaward/btn_blue.png|0,15,34,256"),
  [3] = SHARED("$image/giftaward/btn_tq.png|0,15,36,256"),
  [4] = SHARED("$image/giftaward/btn_rmb.png|0,15,35,256")
}
local btn_image1 = {
  [1] = SHARED("$image/giftaward/btn_qq1.png|0,15,32,256"),
  [2] = SHARED("$image/giftaward/btn_blue1.png|0,15,34,256"),
  [3] = SHARED("$image/giftaward/btn_tq1.png|0,15,36,256"),
  [4] = SHARED("$image/giftaward/btn_rmb1.png|0,15,35,256")
}
function on_down_tip_make(tip)
  local stk = sys.mtf_stack()
  local newline_cnt = 0
  local function push_newline()
    if newline_cnt == 0 then
      newline_cnt = newline_cnt + 1
    else
      ui_tool.ctip_push_newline(stk)
    end
  end
  local function reset_newline()
    newline_cnt = 0
  end
  local function push_group(txt, sep)
    if sep == nil then
      ui_tool.ctip_push_sep(stk)
    end
    reset_newline()
    ui_tool.ctip_push_text(stk, txt .. ui_tool.cs_tip_newline, ui_tool.cs_tip_color_green, ui_tool.cs_tip_a_add_m)
  end
  local push_text = function(stk, text, color)
    if color ~= nil then
      local fmt = ui_tool.cs_tip_c_add_s
      if sys.is_type(color, "number") then
        fmt = ui_tool.cs_tip_c_add
      end
      stk:raw_format(fmt, color)
      stk:raw_push(text)
      stk:raw_push(ui_tool.cs_tip_c_sub)
    else
      stk:raw_push(text)
    end
  end
  local function push_traits(txt, color)
    push_newline()
    push_text(stk, txt, color)
  end
  local parent = tip.owner.parent
  local owner_line = parent.svar.owner_line
  local gift_line = parent.svar.gift_line
  ui_tool.ctip_make_title(stk, owner_line, ui_tool.cs_tip_color_red)
  push_group(ui.get_text(L("gift_award|desc_time")))
  push_traits(owner_line.time)
  push_group(ui.get_text(L("gift_award|desc_info")))
  push_traits(owner_line.desc)
  push_group(ui.get_text(L("gift_award|gift_name")))
  push_traits(gift_line.name)
  push_group(ui.get_text(L("gift_award|gift_desc")))
  push_traits(gift_line.desc)
  if parent.svar.need ~= "" then
    push_group(ui.get_text(L("gift_award|gift_need")))
    push_traits(parent.svar.need, ui_tool.cs_tip_color_red)
  end
  if parent.svar.cd_text ~= "" then
    push_group(ui.get_text(L("gift_award|gift_cooldwon")))
    push_traits(parent.svar.cd_text, ui_tool.cs_tip_color_red)
  end
  ui_widget.tip_make_view(tip.view, stk.text)
end
function on_flag_chg()
  update_all_item()
  update_stepping_btn()
  update_items()
end
function check_flagmsg(check)
  for i = 1, 3 do
    local panel = g_down_card[i]
    if panel.visible == true and panel.svar.gift_line.flag_id ~= 0 then
      if check then
        bo2.player:insert_on_flagmsg(bo2.eFlagType_Bit, panel.svar.gift_line.flag_id, on_flag_chg, "ui_guild_mod.ui_guild.on_flag_chg")
      else
        bo2.player:remove_on_flagmsg(bo2.eFlagType_Bit, panel.svar.gift_line.flag_id, "ui_guild_mod.ui_guild.on_flag_chg")
      end
    end
  end
end
function update_items()
  local _star = (g_page_cur - 1) * 3 + 1
  local _end = g_page_cur * 3
  if _end > g_cur_item.size then
    _end = g_cur_item.size
  end
  for i = 1, 3 do
    local panel = g_down_card[i]
    panel.visible = false
  end
  for i = _star, _end do
    local panel = g_down_card[i - (g_page_cur - 1) * 3]
    panel.visible = true
    panel.svar.need = nil
    local item = g_cur_item:get(i - 1)
    local owner = bo2.gv_gift_award_owner:find(item:get("id").v_int)
    local n = ui_gift_award.ui_svrbeg2.get_cur_gift(owner)
    panel:search("title").text = item:get("name").v_string
    local mail = bo2.gv_mail_list:find(n.mail_id)
    if not mail.item.empty then
      for i, v in string.gmatch(tostring(mail.item), "(%w+)*(%w+)") do
        panel:search("card").excel_id = i
      end
    end
    panel.svar.gift_line = n
    panel.svar.owner_line = owner
    ui_gift_award.ui_svrbeg2.g_request = ""
    local g_btn = panel:search("btn")
    g_btn.enable = true
    g_btn.text = ui.get_text(L("gift_award|get_btn"))
    local comp = 0
    if bo2.player then
      comp = bo2.player:get_flag_bit(n.flag_id)
    end
    if comp == 1 then
      g_btn.text = ui.get_text(L("gift_award|get_btn_over"))
      g_btn.enable = false
    else
      panel.svar.cd_text = ""
      if ui_gift_award.ui_svrbeg2.check_cooldwon(n.cooldown) == false then
        g_btn.text = ui.get_text(L("gift_award|cooldown"))
        g_btn.enable = false
        panel.svar.cd_text = ui_gift_award.ui_svrbeg2.cd_view_text
      end
      if ui_gift_award.ui_svrbeg2.check_premise(n.premise_id) == false then
        g_btn.enable = false
      end
      if ui_gift_award.ui_svrbeg2.check_campaign(n.campaign_id) == false then
        g_btn.enable = false
      end
      if ui_gift_award.ui_svrbeg2.check_other(n.check_type, n.check_max, n.check_min) == false then
        g_btn.enable = false
      end
      if ui_gift_award.ui_svrbeg2.check_item(n.items) == false then
        g_btn.enable = false
      end
    end
    panel.svar.need = ui_gift_award.ui_svrbeg2.g_request
    if item:get("can_give").v_int == 1 then
      panel:search("highlight").visible = true
    else
      panel:search("highlight").visible = false
    end
  end
  check_flagmsg(true)
end
function update_personal_btn()
  local img_qq, img_blue, img_tq, img_rmb
  local qq = bo2.player:get_player_dwordtemp(bo2.ePFlagDwordTemp_QQVIP)
  if qq ~= 0 then
    img_qq = btn_image
  else
    img_qq = btn_image[1]
  end
  local blue = bo2.player:get_player_dwordtemp(bo2.ePFlagDwordTemp_BlueDiamond)
  if qq ~= 0 then
    img_blue = btn_image
  else
    img_blue = btn_image[1]
  end
  local tq = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_RMBPrivilegeHours)
  if qq ~= 0 then
    img_tq = btn_image
  else
    img_tq = btn_image[1]
  end
  local rmb = bo2.player:get_flag_bit(bo2.ePlayerFlagBit_FirstBuyRMB)
  if qq ~= 0 then
    img_rmb = btn_image
  else
    img_rmb = btn_image[1]
  end
  w_win:search("btn_img_qq").image = img_qq[1]
  w_win:search("btn_img_blue").image = img_blue[2]
  w_win:search("btn_img_tq").image = img_tq[3]
  w_win:search("btn_img_rmb").image = img_rmb[4]
end
function on_visible(p, v)
  if sys.check(bo2.player) == false then
    return
  end
  if v == false then
    check_flagmsg(false)
    return
  end
  ui_personal.ui_renown.update_knight_renown()
  local player = bo2.player
  local renown_lvl = player:get_flag_int8(bo2.ePlayerFlagInt8_RenownLvl)
  if renown_lvl < 1 then
    renown_lvl = 1
  end
  local renown_title = bo2.gv_knight_renown:find(renown_lvl)
  if renown_title ~= nil then
    local renown_title_id = renown_title.renown_title_id
    local title = bo2.gv_title_list:find(renown_title_id)
    if title ~= nil then
      w_renown.text = title._name
    end
  end
  local portrait = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
  w_portrait.image = "$icon/portrait/" .. bo2.gv_portrait:find(portrait).icon .. ".png"
  update_all_item()
  update_stepping_btn()
  update_items()
  updata_daily_btn()
  update_personal_btn()
end
function on_broadcast_star(text_id)
  local rich_box = broadcast_panel:search("r_box")
  local timer = broadcast_panel:find_plugin("timer")
  local text = bo2.gv_text:find(text_id).text
  rich_box:item_clear()
  rich_box:insert_mtf(sys.format("<tf:text>%s", text), ui.mtf_rank_system)
  rich_box.x = c_box_x
  timer.period = 25
  timer.suspended = false
end
function on_timer(timer)
  timer.period = 25
  local parent = timer.owner
  local box = parent:search("r_box")
  if box.x + box.extent.x <= 0 then
    timer.suspended = true
    if g_cur_broadcast_idx == g_max_broadcast_idx then
      g_cur_broadcast_idx = 1
    else
      g_cur_broadcast_idx = g_cur_broadcast_idx + 1
    end
    on_broadcast_star(g_broadcast_text[g_cur_broadcast_idx])
    return
  end
  box.x = box.x - 1.6
end
local get_item_flag = function(owner)
  if bo2.player == nil then
    return 0
  end
  local n = ui_gift_award.ui_svrbeg2.get_cur_gift(owner)
  if n == nil then
    return 0
  else
    return bo2.player:get_flag_bit(n.flag_id)
  end
end
function update_all_item()
  local gift_count = 0
  g_cur_item:clear()
  for i = 0, g_all_item.size - 1 do
    local item = g_all_item:get(i)
    local owner = bo2.gv_gift_award_owner:find(item:get("id").v_int)
    local n = ui_gift_award.ui_svrbeg2.get_cur_gift(owner)
    local flag_v = get_item_flag(owner)
    if n ~= nil and ui_gift_award.ui_svrbeg2.check_campaign(n.campaign_id) == true then
      g_cur_item:push_back(item)
      local can_give = 0
      item:set("can_give", 0)
      if ui_gift_award.ui_svrbeg2.check_on_visible(n) == true and flag_v == 0 then
        item:set("can_give", 1)
        can_give = 1
        gift_count = gift_count + 1
      end
      if n == nil or n.mail_id == 0 then
        item:set("sort_id", 3)
      elseif flag_v == 1 then
        item:set("sort_id", 4)
      elseif can_give == 0 then
        item:set("sort_id", 2)
      elseif n.make_up == 0 then
        item:set("sort_id", 0)
      else
        item:set("sort_id", 1)
      end
    end
  end
  local fn = function(src, tar)
    local src_sort = src:get("sort_id").v_int
    local tar_sort = tar:get("sort_id").v_int
    if src_sort < tar_sort then
      return true
    elseif src_sort == tar_sort then
      local src_id = src:get("id").v_int
      local tar_id = tar:get("id").v_int
      return src_id < tar_id
    else
      return false
    end
  end
  g_cur_item:sort(fn)
  ui_gift_award.g_cur_gifts[w_win.name] = gift_count
  g_page_cur = 1
  g_page_max = math.ceil(g_cur_item.size / 3)
end
function on_init()
  g_broadcast_text = {}
  local broadcast_table = bo2.gv_define_v:find(27).value
  for i = 0, broadcast_table.size - 1 do
    table.insert(g_broadcast_text, broadcast_table[i])
  end
  g_cur_broadcast_idx = 1
  g_max_broadcast_idx = #g_broadcast_text
  on_broadcast_star(g_broadcast_text[g_cur_broadcast_idx])
  g_all_item = sys.variant()
  g_cur_item = sys.variant()
  g_down_card[1] = w_down_card1
  g_down_card[2] = w_down_card2
  g_down_card[3] = w_down_card3
  for i = 0, bo2.gv_gift_award_owner.size - 1 do
    local n = bo2.gv_gift_award_owner:get(i)
    if n.type == 1 or n.type == 4 then
      local item = sys.variant()
      item:set("id", n.id)
      item:set("name", n.name)
      item:set("flag", n.flag)
      g_all_item:push_back(item)
    end
  end
  for i = 1, 6 do
    local panel = w_win:search("card" .. i)
    panel:search("btn").enable = false
    if i ~= 6 then
      panel:search("highlight").visible = false
      panel:search("pic").visible = false
    end
    local n = bo2.gv_gift_award:find(99 + i)
    panel.svar.gift_line = n
    panel.svar.show_text = false
    g_daily_btn[i] = panel
  end
end
function on_qq_btn_click(btn)
  ui_widget.ui_tab.show_page(ui_gift_award.w_win, "serverbegin_main2", true)
  local list = ui_gift_award.ui_svrbeg2.g_svrbeg_list
  for i = 0, list.item_count - 1 do
    local item = list:item_get(i)
    if item.svar.qq_type == 1 then
      item:select(true, false)
      return
    end
  end
end
function on_blue_btn_click(btn)
  ui_widget.ui_tab.show_page(ui_gift_award.w_win, "serverbegin_main2", true)
  local list = ui_gift_award.ui_svrbeg2.g_svrbeg_list
  for i = 0, list.item_count - 1 do
    local item = list:item_get(i)
    if item.svar.qq_type == 2 then
      item:select(true, false)
      return
    end
  end
end
function on_tq_btn_click(btn)
  ui_supermarket2.w_privilege.visible = true
end
function on_rmb_btn_click(btn)
  ui_supermarket2.money_BuyRMB(btn)
end
function update_stepping_btn()
  w_btn_left.enable = true
  w_btn_right.enable = true
  if g_page_cur == 1 then
    w_btn_left.enable = false
  elseif g_page_cur == g_page_max then
    w_btn_right.enable = false
  end
end
function on_stepping_left(btn)
  check_flagmsg(false)
  g_page_cur = g_page_cur - 1
  update_items()
  update_stepping_btn()
end
function on_stepping_right(btn)
  check_flagmsg(false)
  g_page_cur = g_page_cur + 1
  update_items()
  update_stepping_btn()
end
function on_gift_btn_click(btn)
  local item = btn.parent
  local v = sys.variant()
  v:set(packet.key.cmn_id, item.svar.gift_line.id)
  bo2.send_variant(packet.eCTS_GiftAward_Get, v)
  local reset_sel = function()
    update_all_item()
    update_stepping_btn()
    update_items()
  end
  bo2.AddTimeEvent(10, reset_sel)
end
function updata_daily_btn()
  g_daily_can_give_idx = 0
  for i = 1, 5 do
    local panel = g_daily_btn[i]
    local n = panel.svar.gift_line
    local flag = bo2.player:get_flag_bit(n.flag_id)
    local btn = panel:search("btn")
    local pic = panel:search("pic")
    if flag == 1 then
      btn.enable = false
      btn.visible = false
      panel:search("highlight").visible = false
      pic.visible = true
      pic:search("txt").text = ui.get_text(L("gift_award|get_btn_over"))
      local mail = bo2.gv_mail_list:find(n.mail_id)
      if not mail.item.empty then
        for i, v in string.gmatch(tostring(mail.item), "(%w+)*(%w+)") do
          pic:search("card").excel_id = i
        end
      end
      g_daily_can_give_idx = i
    elseif ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
      btn.enable = true
      btn.visible = true
      panel:search("highlight").visible = true
      pic.visible = false
      g_daily_can_give_idx = i
    elseif g_daily_can_give_idx + 1 == i then
      btn.enable = true
      btn.visible = true
      panel:search("highlight").visible = false
      pic.visible = false
    else
      btn.enable = false
      btn.visible = true
      panel:search("highlight").visible = false
      pic.visible = false
    end
  end
  local panel = g_daily_btn[6]
  if g_daily_can_give_idx == 5 and ui_gift_award.ui_svrbeg2.check_on_visible(panel.svar.gift_line) == true then
    panel:search("btn").enable = true
  else
    panel:search("btn").enable = false
  end
end
function on_daily_btn_click(btn)
  local panel = btn.parent
  local v = sys.variant()
  v:set(packet.key.cmn_id, panel.svar.gift_line.id)
  bo2.send_variant(packet.eCTS_GiftAward_Get, v)
  local reset_sel = function()
    updata_daily_btn()
  end
  bo2.AddTimeEvent(10, reset_sel)
end
function on_gift_timer()
  if sys.check(bo2.player) == false then
    return
  end
  local gift_count = 0
  for i = 0, g_all_item.size - 1 do
    local item = g_all_item:get(i)
    local owner = bo2.gv_gift_award_owner:find(item:get("id").v_int)
    local n = ui_gift_award.ui_svrbeg2.get_cur_gift(owner)
    local flag_v = get_item_flag(owner)
    if ui_gift_award.ui_svrbeg2.check_on_visible(n) == true and flag_v == 0 then
      gift_count = gift_count + 1
      if item:has("show_text") == false then
        local arg = sys.variant()
        arg:set(L("name"), n.name)
        ui_chat.show_ui_text_id(73186, {
          name = n.name
        })
        item:set("show_text", 1)
      end
    end
  end
  for i = 1, 6 do
    local panel = g_daily_btn[i]
    local n = panel.svar.gift_line
    if bo2.player:get_flag_bit(n.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
      gift_count = gift_count + 1
      if panel.svar.show_text == false then
        local arg = sys.variant()
        arg:set(L("name"), n.name)
        ui_chat.show_ui_text_id(73186, {
          name = n.name
        })
        panel.svar.show_text = true
      end
    end
  end
  ui_gift_award.g_cur_gifts[w_win.name] = gift_count
end
