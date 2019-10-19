local g_broadcast_text = {}
local g_cur_broadcast_idx = 0
local g_max_broadcast_idx = 0
local c_box_x = 672
local g_daily_btn = {}
local g_daily_can_give_idx = 1
local g_top_right_giftid = 1007
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
    if title ~= nil and w_renown ~= nil then
      w_renown.text = title._name
    end
  end
  local portrait = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
  w_portrait.image = "$icon/portrait/" .. bo2.gv_portrait:find(portrait).icon .. ".png"
  updata_daily_btn()
  update_personal_btn()
  updata_top_right_btn()
end
function check_zone_zh_cn_visible(ctrl)
  ctrl.visible = bo2.get_zone() == L("zh_cn")
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
  g_page_cur = 1
  g_page_max = math.ceil(g_cur_item.size / 3)
end
function check_all()
  local n = bo2.gv_gift_award:find(g_top_right_giftid)
  if ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
    return true
  end
  for i = 1, 6 do
    local panel = g_daily_btn[i]
    local n = panel.svar.gift_line
    if bo2.player:get_flag_bit(n.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
      return true
    end
  end
  return false
end
function check_and_get_once()
  local n = bo2.gv_gift_award:find(g_top_right_giftid)
  if ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
    local btn = ui_gift_login.g_top_right_btn
    on_top_right_click_btn(btn)
  end
  for i = 1, 6 do
    local panel = g_daily_btn[i]
    local n = panel.svar.gift_line
    if bo2.player:get_flag_bit(n.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
      local btn = panel:search("card")
      on_daily_btn_click(btn)
    end
  end
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
  for i = 1, 6 do
    local panel = w_win:search("card" .. i)
    panel:search("btn").enable = false
    panel:search("highlight").visible = false
    panel:search("pic").visible = false
    local n = bo2.gv_gift_award:find(1000 + i)
    panel.svar.gift_line = n
    panel.svar.show_text = false
    g_daily_btn[i] = panel
    local items = n.award_items
    if items ~= nil and items.size >= 1 then
      panel:search("card").excel_id = items[0]
    end
    local count = n.items_count
    if count ~= nil and count.size >= 1 and count[0] > 1 then
      panel:search("item_count").text = count[0]
    end
  end
  local n = bo2.gv_gift_award:find(g_top_right_giftid)
  local top_right_items = n.award_items
  local items_count = n.items_count
  for i = 1, 5 do
    local itempanel = w_top_right_card:search("top_card" .. i)
    if itempanel ~= nil then
      local card = itempanel:search("card")
      card.excel_id = top_right_items[i - 1]
      if 1 < items_count[i - 1] then
        local count = itempanel:search("item_count")
        count.text = items_count[i - 1]
      end
    end
  end
  ui_gift_award.push_check_timer("login", check_all)
  ui_gift_award.push_check_get_all("login", check_and_get_once)
end
function on_qq_btn_click(btn)
  local w = ui_gift_award.g_all_items.qq_vip
  local b = w.svar.btn
  ui_gift_award.on_btn_click(b)
end
function on_blue_btn_click(btn)
  local w = ui_gift_award.g_all_items.qq_blue
  local b = w.svar.btn
  ui_gift_award.on_btn_click(b)
end
function on_tq_btn_click(btn)
  ui_supermarket2.w_privilege.visible = true
end
function on_rmb_btn_click(btn)
  ui_supermarket2.money_BuyRMB(btn)
end
function updata_daily_btn()
  g_daily_can_give_idx = 0
  for i = 1, 6 do
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
      panel:search("txt").text = ui.get_text(L("gift_award|get_btn_over"))
      local mail = bo2.gv_mail_list:find(n.mail_id)
      if not mail.item.empty then
        for i, v in string.gmatch(tostring(mail.item), "(%w+)*(%w+)") do
          panel:search("card").excel_id = i
        end
      end
      g_daily_can_give_idx = i
    elseif ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
      btn.enable = true
      btn.visible = true
      panel:search("highlight").visible = true
      pic.visible = false
      g_daily_can_give_idx = i
    else
      btn.enable = false
      btn.visible = true
      btn:search("btn_color").visible = true
      panel:search("txt").visible = false
      panel:search("highlight").visible = false
      pic.visible = false
    end
  end
end
function on_daily_btn_mouse(card, msg)
  local p = card.parent
  if p ~= nil and p:search("btn") ~= nil and p:search("btn").enable == true and msg == ui.mouse_lbutton_click then
    on_daily_btn_click(card)
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
function updata_top_right_btn()
  local n = bo2.gv_gift_award:find(g_top_right_giftid)
  if ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
    g_top_right_btn.enable = true
  else
    g_top_right_btn.enable = false
  end
end
function on_top_right_click_btn(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_id, g_top_right_giftid)
  bo2.send_variant(packet.eCTS_GiftAward_Get, v)
  local reset_sel = function()
    updata_top_right_btn()
  end
  bo2.AddTimeEvent(10, reset_sel)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_gift_login.packet_handle"
function handle_open_win(cmd, data)
  if data:get(packet.key.ui_window_type).v_string ~= L("gift_award_login") then
    return
  end
  local name = "login"
  local vis = ui_gift_award.check_win_vis(name, v)
  if vis == false then
    w_win.visible = false
  else
    w_win.visible = true
  end
end
reg(packet.eSTC_UI_OpenWindow, handle_open_win, sig)
