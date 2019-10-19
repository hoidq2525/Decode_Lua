gv_text_book_config = sys.load_table("$mb/etc/text_book_config.xml")
local g_line_in_page = 14
function show_text_book(config_id)
  w_main.visible = true
  local tb_line = gv_text_book_config:find(config_id)
  if tb_line == nil then
    ui.log("!!!!INPUT ERROR!!!!config_id")
    return
  end
  local txt_line = bo2.gv_text:find(tb_line.text_id)
  if txt_line == nil then
    ui.log("!!!!INPUT ERROR!!!!text_id")
    return
  end
  local txt_info = txt_line.text
  w_info_rb.mtf = txt_info
  ui_main.w_top:apply_dock(true)
  w_info_rb:update_view()
  local img_name = tb_line.img_name
  local img_url = L("$image/text_book/") .. img_name .. L(".png")
  if sys.is_file(img_url) == false then
    ui.log("!!!!IMAGE DOESN'T EXIST!!!!")
    return
  end
  img_url = img_url .. L("|0,0,384,512")
  w_pic_bg.image = img_url
  local cur_line_cnt = w_info_rb.line_count
  ui.log("line_count:" .. cur_line_cnt)
  local page_cnt = math.ceil(cur_line_cnt / g_line_in_page)
  local add_line_cnt = g_line_in_page * page_cnt - cur_line_cnt
  for i = 1, add_line_cnt do
    txt_info = txt_info .. L("\n")
  end
  w_info_rb.mtf = txt_info
  ui_widget.ui_stepping.set_page(w_step, 0, page_cnt)
  update_page(w_step.svar.stepping)
end
function on_main_init(ctrl)
  ui_widget.ui_stepping.set_event(w_step, update_page)
end
function on_main_close(btn)
  w_main.visible = false
end
function on_main_visible(ctrl, vis)
  ui_widget.on_border_visible(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  w_main.dock = "pin_xy"
end
function update_page(var)
  local page_idx = var.index
  local page_cnt = var.count
  w_info_rb.slider_y.scroll = page_idx / (page_cnt - 1)
end
