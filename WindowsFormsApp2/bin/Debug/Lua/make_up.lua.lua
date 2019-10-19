local cur_gift = 0
function on_init()
  local vis = false
  g_desc_box.mtf = ui.get_text("gift_award|no_make_up")
  for i = 0, bo2.gv_gift_award_owner.size - 1 do
    local n = bo2.gv_gift_award_owner:get(i)
    if n.type == 4 and n.gift.size ~= 0 then
      g_desc_box.mtf = n.desc
      cur_gift = n.gift[0]
      local gift_line = bo2.gv_gift_award:find(cur_gift)
      local mail_line = bo2.gv_mail_list:find(gift_line.mail_id)
      for item_id, _ in string.gmatch(tostring(mail_line.item), "(%w+)*(%w+)") do
        g_item_view.excel_id = item_id
        vis = true
      end
    end
  end
  w_win:search("item_view").visible = vis
  g_btn.visible = vis
end
function on_visible(p, v)
  if v == false then
    return
  end
  if cur_gift == 0 then
    return
  end
  local n = bo2.gv_gift_award:find(cur_gift)
  g_btn.enable = ui_gift_award.ui_svrbeg.check_on_visible(n)
  local comp = 0
  local can_get = false
  if bo2.player then
    comp = bo2.player:get_flag_bit(n.flag_id)
    local cur_gift_id = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_MakeUpGiftID)
    if cur_gift_id == cur_gift then
      can_get = true
    end
  end
  if comp == 1 or can_get == false then
    g_btn.text = ui.get_text(L("gift_award|get_btn_over"))
  end
end
function on_click_btn(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_id, cur_gift)
  bo2.send_variant(packet.eCTS_GiftAward_Get, v)
end
