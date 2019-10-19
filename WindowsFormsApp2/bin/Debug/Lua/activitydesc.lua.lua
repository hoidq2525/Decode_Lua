local reg = ui_packet.game_recv_signal_insert
local sig = "ui_activitydesc.packet_handler"
desc_table = sys.load_table("$mb/scn/activitydesc.xml")
c_text_item_file = L("$frame/activitydesc/activitydesc.xml")
c_text_item_cell = L("desc_item")
local inf_list = {}
local desc_pages = {}
local MAX_NUM = 5
local CATCH_TIME = 7
function adjust_size()
  w_frame.size = ui.point(360, inf_list.cnt * 60)
end
function add_desc_item(whichone)
  local record = bo2.gv_activitydesc:find(whichone)
  if record == nil then
    return
  end
  if false == w_frame.visible then
    inf_list = {}
    desc_pages = {}
    list_init()
  end
  if desc_list.item_count >= MAX_NUM then
    rmv_desc_item(MAX_NUM - 1)
  end
  local cnt = desc_list.item_count
  local item = desc_list:item_insert(0)
  item:load_style(c_text_item_file, c_text_item_cell)
  item:search("title").text = record.title
  item:search("desc").text = record.preDesc
  item:search("itembg").image = "$image/activity/" .. record.itemBg .. ".png"
  item:search("itembtnbg").image = "$image/activity/" .. record.itemBtnBg .. ".png|1,8,32,112"
  local itemfader = item:search("desc_fader")
  itemfader.alpha = 0
  for i = inf_list.cnt, 1, -1 do
    inf_list[i] = inf_list[i - 1]
  end
  inf_list[0] = {
    lasted = record.dwellTime * 40,
    total = record.dwellTime * 40,
    citem = item,
    crecord = record,
    isOnAnim = false,
    curSize = 60
  }
  local font_color = record.font_color
  if L("") == font_color then
    font_color = "ffffff"
  end
  inf_list[0].color = font_color
  inf_list.cnt = inf_list.cnt + 1
  if w_frame.visible == false then
    w_frame.visible = true
    desc_timer.suspended = false
  end
end
function rmv_desc_item(index)
  desc_list:item_remove(index)
  for i = index, inf_list.cnt - 2 do
    inf_list[i] = inf_list[i + 1]
  end
  inf_list.cnt = inf_list.cnt - 1
  adjust_size()
  if desc_list.item_count <= 0 then
    w_frame.visible = false
    desc_timer.suspended = true
  end
end
function set_cur_desc_page()
  if desc_pages.cnt > 0 then
    local idx = desc_pages.cur
    w_title:search("d_title").text = desc_pages[idx].ptitle
    w_desc:search("d_desc").color = ui.make_color(desc_pages[idx].color)
    w_desc:search("d_desc").mtf = desc_pages[idx].pdescribe
    w_title:search("titlebg").image = "$image/" .. desc_pages[idx].pimg1
    w_desc:search("descbg").image = "$image/" .. desc_pages[idx].pimg2
    if desc_pages.cnt > 1 then
      local curt = desc_pages.cur + 1
      w_bottom:search("page_info").text = curt .. "/" .. desc_pages.cnt
      if curt >= desc_pages.cnt then
        w_btn_nxt.enable = false
      else
        w_btn_nxt.enable = true
      end
      if curt <= 1 then
        w_btn_pre.enable = false
      else
        w_btn_pre.enable = true
      end
      w_bottom.visible = true
    else
      w_bottom.visible = false
    end
    w_window.visible = true
  else
    w_window.visible = false
  end
end
function add_desc_page(index)
  local cnt = desc_pages.cnt
  local record = inf_list[index].crecord
  desc_pages[cnt] = {
    ptitle = record.title,
    pdescribe = record.intro,
    pimg1 = record.titlebgPic,
    pimg2 = record.descbgPic,
    color = inf_list[index].color
  }
  desc_pages.cnt = cnt + 1
  desc_pages.cur = cnt
  set_cur_desc_page()
end
function del_desc_page(index)
  local cnt = desc_pages.cnt
  for i = index, cnt - 2 do
    desc_pages[i] = desc_pages[i + 1]
  end
  desc_pages.cnt = cnt - 1
  if desc_pages.cur >= desc_pages.cnt then
    desc_pages.cur = cnt - 2
  end
  set_cur_desc_page()
end
function on_btn_nxt()
  desc_pages.cur = desc_pages.cur + 1
  if desc_pages.cur >= desc_pages.cnt then
    desc_pages.cur = desc_pages.cnt - 1
  end
  set_cur_desc_page()
end
function on_btn_pre()
  desc_pages.cur = desc_pages.cur - 1
  if desc_pages.cur <= 0 then
    desc_pages.cur = 0
  end
  set_cur_desc_page()
end
function on_desc_close()
  do break end
  do break end
  del_desc_page(desc_pages.cur)
  set_cur_desc_page()
end
function on_desc_click(btn)
  local tidx = btn:upsearch_name("w_desc_item").index
  add_desc_page(tidx)
  rmv_desc_item(tidx)
end
function list_init()
  inf_list.cnt = 0
  desc_pages.cnt = 0
  desc_pages.cur = 0
  desc_list:item_clear()
end
function time_updata()
  local isOnAnim = false
  for i = 0, desc_list.item_count - 1 do
    local node = inf_list[i]
    local diff = node.total - node.lasted
    if node.citem.visible == false then
      node.citem.visible = true
      adjust_size()
    end
    if diff < 40 then
      node.citem.size = ui.point(60, 60)
    end
    if diff == 40 then
      node.isOnAnim = true
      local itemfader = node.citem:search("desc_fader")
      itemfader:reset(0, 1, 500)
      node.citem:search("btn_flicker").dock = "pin_x2"
    end
    if node.lasted == 100 then
      local itemfader = node.citem:search("desc_fader")
      itemfader:reset(1, 0.08, node.lasted * 25)
    end
    if node.isOnAnim then
      if node.curSize < 252 then
        node.citem.size = ui.point(math.ceil(node.curSize), 60)
        node.curSize = node.curSize + 18
        isOnAnim = true
      else
        node.citem.size = ui.point(320, 60)
        node.isOnAnim = false
      end
    end
  end
  if isOnAnim == false then
    for i = 0, desc_list.item_count - 1 do
      local node = inf_list[i]
      if 0 >= node.lasted then
        rmv_desc_item(i)
        break
      end
    end
  end
  for i = 0, desc_list.item_count - 1 do
    inf_list[i].lasted = inf_list[i].lasted - 1
  end
end
function on_timer()
  time_updata()
end
function on_init()
  list_init()
end
function show_huodonginfo(cmd, data)
  local idv = data:get(packet.key.cmn_id).v_int
  ui.log("idv")
  ui.log(idv)
  add_desc_item(idv)
end
reg(packet.eSTC_UI_Huodong_Info, show_huodonginfo, sig)
