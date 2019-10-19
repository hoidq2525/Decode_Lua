local reg = ui_packet.game_recv_signal_insert
local sig = "ui_guitest.packet_handler"
desc_table = sys.load_table("$mb/scn/guitest_ui.xml")
c_text_item_file = L("$frame/guitest/guitest.xml")
c_text_item_cell = L("desc_item")
local inf_list = {}
local desc_pages = {}
local MAX_NUM = 5
local CATCH_TIME = 7
function adjust_size()
  w_frame.size = ui.point(280, inf_list.cnt * 60 + 180)
end
function add_desc_item(whichone)
  local record = desc_table:find(whichone)
  if record == nil then
    return
  end
  if desc_list.item_count >= MAX_NUM then
    rmv_desc_item(MAX_NUM - 1)
  end
  local cnt = desc_list.item_count
  local item = desc_list:item_insert(0)
  item:load_style(c_text_item_file, c_text_item_cell)
  local sub = ui.create_control(item, "button")
  sub:load_style(c_text_item_file, "sub_btn")
  sub:search("subbtnbg").image = "$image/activity/" .. record.itemBtnBg .. ".png|2,7,32,120"
  item:search("title").text = record.title
  item:search("desc").text = record.preDesc
  item:search("itembg").image = "$image/activity/" .. record.itemBg .. ".png"
  item:search("itembtnbg").image = "$image/activity/" .. record.itemBtnBg .. ".png|2,7,32,120"
  local dstp = item:search("btn_flicker")
  item:apply_dock(true)
  local function checkDescFnc()
    local w_hide_anim = ui_qbar.ui_hide_anim.w_hide_anim
    local bs = dstp.size
    local ws = sub.size
    local src = sub:control_to_window(ui.point(0, 0)) - sub.offset
    local dis = dstp:control_to_window(ui.point(0, 0)) - sub.offset
    local len = dis - src
    local tick = math.sqrt(math.sqrt(len.x * len.x + len.y * len.y)) * 30
    if tick < 100 then
      tick = 100
    end
    w_hide_anim.svar.target = sub
    w_hide_anim:frame_clear()
    w_hide_anim.visible = true
    local f = w_hide_anim:frame_insert(100, sub)
    f.color1 = "FFFFFFFF"
    f.color2 = "CCFFFFFF"
    f:set_scale1(1, 1)
    f:set_scale2(1.2, 1.2)
    f:set_translate1(src.x, src.y)
    f:set_translate2(src.x, src.y)
    f = w_hide_anim:frame_insert(tick, sub)
    f.color1 = "CCFFFFFF"
    f.color2 = "99FFFFFF"
    f:set_scale1(1.2, 1.2)
    f:set_scale2(1.2, 1.2)
    f:set_translate1(src.x, src.y)
    f:set_translate2(dis.x, dis.y)
    f = w_hide_anim:frame_insert(100, sub)
    f.color1 = "99FFFFFF"
    f.color2 = "00FFFFFF"
    f:set_scale1(1.2, 1.2)
    f:set_scale2(1, 1)
    f:set_translate1(dis.x, dis.y)
    f:set_translate2(dis.x, dis.y)
  end
  ui_qbar.ui_hide_anim.bind(sub, dstp, nil, checkDescFnc)
  for i = inf_list.cnt, 1, -1 do
    inf_list[i] = inf_list[i - 1]
  end
  inf_list[0] = {
    lasted = record.dwellTime,
    total = record.dwellTime,
    citem = item,
    crecord = record,
    csub = sub
  }
  inf_list.cnt = inf_list.cnt + 1
  adjust_size()
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
    w_desc:search("d_desc").mtf = desc_pages[idx].pdescribe
    w_title:search("titlebg").image = "$image/activity/actbgs/" .. desc_pages[idx].pimg1 .. ".png"
    w_desc:search("descbg").image = "$image/activity/actbgs/" .. desc_pages[idx].pimg2 .. ".png"
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
    pimg2 = record.descbgPic
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
  local list_tmp = {cnt = 0}
  for i = 0, inf_list.cnt - 1 do
    inf_list[i].lasted = inf_list[i].lasted - 1
    if 0 >= inf_list[i].lasted then
      desc_list:item_remove(i)
      inf_list[i] = nil
    else
      list_tmp[list_tmp.cnt] = inf_list[i]
      list_tmp.cnt = list_tmp.cnt + 1
    end
  end
  inf_list = list_tmp
  for i = 0, inf_list.cnt - 1 do
    local node = inf_list[i]
    local item = node.citem
    local alpha = 1 * node.lasted / node.total
    local itemfader = item:search("desc_fader")
    itemfader:reset(itemfader.alpha, alpha, 1000)
    if node.total - node.lasted >= 2 then
      node.csub.visible = false
    end
  end
  adjust_size()
  if desc_list.item_count == 0 then
    w_frame.visible = false
    desc_timer.suspended = true
  end
end
which = 1
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
