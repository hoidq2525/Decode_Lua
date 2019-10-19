local MAX_SHOW_COUNT = 50
local SYS_MAIL_FLAG = 0
local IM_MAIL_FLAG = 1
local DEFINE_ITEM_COUNT = 11
local current_item_count = 0
local read_item_count = 0
function OnInit()
  g_unshowMails = {}
  g_showedMails = {}
  gx_mailList:item_clear()
  read_item_count = 0
  current_item_count = 0
  if gx_toggle then
    gx_toggle:insert_on_click(function()
      gx_window.visible = not gx_window.visible
    end)
  end
end
function on_timer()
  gx_toggle_light.visible = not gx_toggle_light.visible
end
local function isPackage(mt)
  return mt.type == SYS_MAIL_FLAG and not mt.script.empty
end
local function renderMailItem(item, mt, newAdd)
  if newAdd then
    item:load_style("$frame/mail/mail.xml", "mailitem")
  end
  item:search("text").text = mt.title
  if mt.time ~= 0 then
    item:search("time").text = os.date("%m/%d/%Y", mt.time)
  else
    item:search("time").text = os.date("%m/%d/%Y", os.time())
  end
  if mt.read then
    item:search("mark_rd").visible = true
    item:search("mark_ur").visible = false
    if newAdd then
      read_item_count = read_item_count + 1
    end
  end
  item:search("delselect").visible = not isPackage(mt)
  item:search("enclosure").visible = isPackage(mt)
  if isPackage(mt) then
    enclosure_count.text = enclosure_count.text.v_int + 1
  end
end
local deleteMail = function(mt)
  local v = sys.variant()
  v:set(packet.key.mail_db_id, mt.id)
  bo2.send_variant(packet.eCTS_Mail_Delete, v)
end
local postLeaveWord = function(mt)
  ui.log("postLeaveWord %s", mt.id)
  ui_im.set_leaveword(mt)
end
local findMail = function(id)
  for item, mt in pairs(g_showedMails) do
    if mt.id == id then
      return item, mt
    end
  end
end
local renderMailContent = function(mt)
  gx_mailContent.mtf = mt.content
end
local function updateMail(mt, item, oldMt)
  if mt.title then
    oldMt.title = mt.title
  end
  oldMt.content = mt.content
  oldMt.script = mt.script
  if item == gx_mailList.item_sel then
    renderMailContent(mt)
  end
end
function AddMail(mt)
  if mt.type == IM_MAIL_FLAG then
    postLeaveWord(mt)
    return
  end
  local item, oldMt = findMail(mt.id)
  if oldMt then
    updateMail(mt, item, oldMt)
    renderMailItem(item, oldMt, false)
    return
  end
  if gx_mailList.item_count >= MAX_SHOW_COUNT then
    ui_chat.show_ui_text_id(1516)
    table.insert(g_unshowMails, mt)
    server_count.text = #g_unshowMails
    return
  end
  if not mt.title then
    mt.title = ui.get_text("mail|notitle")
  end
  local unread = not mt.read and not gx_window.visible
  local item
  item = gx_mailList:item_insert(0)
  if unread then
    local data = sys.variant()
    data:set(L("item"), item)
    ui_popo.AddPopo("mail", data)
    gx_timer.suspended = false
  end
  renderMailItem(item, mt, true)
  g_showedMails[item] = mt
  current_item_count = current_item_count + 1
  letter_count.text = current_item_count - read_item_count .. "/" .. current_item_count
  if current_item_count == read_item_count then
    gx_timer.suspended = true
    gx_toggle_light.visible = false
  else
    gx_timer.suspended = false
  end
end
function Show(_, data)
  local item = data:get(L("item")).v_object
  if sys.check(item) == true then
    item:select(true, false)
  end
  gx_window.visible = true
end
function markMailAsRead(mt)
  mt.read = true
  local v = sys.variant()
  v:set(packet.key.mail_db_id, mt.id)
  bo2.send_variant(packet.eCTS_Mail_Read, v)
end
function OnSelectMailItem(item, sel)
  ui_guild_mod.ui_guild.update_highlight(item)
  item:search("fig_highlight_sel").visible = item.selected or item.inner_hover
  if sel then
    item:search("mark_rd").visible = true
    item:search("mark_ur").visible = false
    local mt = g_showedMails[item]
    if mt then
      renderMailContent(mt)
      gx_mailenclosure.visible = isPackage(mt)
      if not mt.read then
        markMailAsRead(mt)
        read_item_count = read_item_count + 1
        letter_count.text = current_item_count - read_item_count .. "/" .. current_item_count
      end
    else
      gx_mailContent.mtf = "no this mail"
    end
  end
  if current_item_count == read_item_count then
    gx_timer.suspended = true
    gx_toggle_light.visible = false
  else
    gx_timer.suspended = false
  end
end
function SelectAll()
  local cnt = gx_mailList.item_count - 1
  for i = 0, cnt do
    local item = gx_mailList:item_get(i)
    item:search("delselect").check = true
  end
end
function SelectRevert()
  local cnt = gx_mailList.item_count - 1
  for i = 0, cnt do
    local item = gx_mailList:item_get(i)
    local btn = item:search("delselect")
    btn.check = not btn.check
  end
end
local function removeMails(mails, svrDel)
  for i, item in ipairs(mails) do
    local mt = g_showedMails[item]
    if mt and svrDel then
      deleteMail(mt)
    end
    if mt.read then
      read_item_count = read_item_count - 1
    end
    g_showedMails[item] = nil
    item:self_remove()
    current_item_count = current_item_count - 1
  end
  local function canAddNew()
    return gx_mailList.item_count < MAX_SHOW_COUNT and #g_unshowMails > 0
  end
  while canAddNew() do
    local mt = g_unshowMails[1]
    AddMail(mt)
    table.remove(g_unshowMails, 1)
  end
  letter_count.text = current_item_count - read_item_count .. "/" .. current_item_count
  server_count.text = #g_unshowMails
  if current_item_count == read_item_count then
    gx_timer.suspended = true
    gx_toggle_light.visible = false
  else
    gx_timer.suspended = false
  end
end
function DeleteMails()
  local mails = {}
  local cnt = gx_mailList.item_count - 1
  for i = 0, cnt do
    local item = gx_mailList:item_get(i)
    if item:search("delselect").check then
      table.insert(mails, item)
    end
  end
  local mails2 = {}
  for i, item in ipairs(mails) do
    local mt = g_showedMails[item]
    if not mt or not isPackage(mt) then
      table.insert(mails2, item)
    end
  end
  if #mails2 == 0 then
    ui_chat.show_ui_text_id(2066)
  else
    removeMails(mails2, true)
  end
end
function OnSetMail(mailID, opr)
  if opr ~= 1 then
    return
  end
  local item, mt = findMail(mailID)
  if mt then
    removeMails({item}, false)
  end
end
function CheckCurMailContent()
  if not gx_window.visible then
    return
  end
  local item = gx_mailList.item_sel
  if not item then
    gx_mailContent.mtf = nil
    gx_packageBtn.visible = false
  end
end
function RequestPackage()
  local item = gx_mailList.item_sel
  if not item then
    gx_packageBtn.visible = false
    return
  end
  local mt = g_showedMails[item]
  if mt and isPackage(mt) then
    local v = sys.variant()
    v:set(packet.key.mail_db_id, mt.id)
    bo2.send_variant(packet.eCTS_Mail_Package, v)
  end
  gx_mailenclosure.visible = false
  gx_packageBtn.visible = false
  enclosure_count.text = enclosure_count.text.v_int - 1
end
function GetUnReadCount()
  return current_item_count - read_item_count
end
function on_make_tip_letter_count(tip)
  tip.text = sys.format(ui.get_text("mail|tip_letter_count"), letter_count.text.v_int)
  ui_widget.tip_make_view(tip.view, tip.text)
end
function on_make_tip_server_count(tip)
  tip.text = sys.format(ui.get_text("mail|tip_server_count"), #g_unshowMails)
  ui_widget.tip_make_view(tip.view, tip.text)
end
function on_make_tip_enclosure_count(tip)
  tip.text = sys.format(ui.get_text("mail|tip_enclosure_count"), enclosure_count.text.v_int)
  ui_widget.tip_make_view(tip.view, tip.text)
end
function on_enclosure_mouse(p, msg)
  if msg == ui.mouse_lbutton_click then
    RequestPackage()
  end
end
function on_make_tip_enclosure(tip)
  tip.text = ui.get_text("mail|mailenclosure")
  ui_widget.tip_make_view(tip.view, tip.text)
end
