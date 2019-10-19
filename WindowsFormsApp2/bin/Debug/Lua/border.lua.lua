local default_lens = 150
local item_type_name_list = {}
item_type_name_list[1] = "text_item"
item_type_name_list[2] = "progress_item"
item_type_name_list[3] = "timer_item"
local border_table = {}
local max_lens = 0
function insert_item(data_var)
  local item_type = data_var:get(packet.key.common_border_type).v_int
  local item_type_name = item_type_name_list[item_type]
  if item_type_name == nil then
    return
  end
  local uri = "$frame/common_border/border.xml"
  local style = item_type_name
  local id = data_var:get(packet.key.common_border_id).v_int
  local item_data = border_table[id]
  if item_data ~= nil then
    remove(id)
  end
  local cur_row = w_list:item_append()
  local idx = w_list.item_count - 1
  cur_row:load_style(uri, style)
  border_table[id] = {}
  border_table[id].type = item_type
  border_table[id].idx = idx
  border_table[id].item = cur_row
  local main_lens = 0
  if item_type == bo2.eCommonBorderType_Text then
    local lens = data_var:get(packet.key.common_border_text_lens).v_int
    if lens == 0 or lens == nil then
      lens = default_lens
    end
    cur_row.dx = lens
    main_lens = lens
  elseif item_type == bo2.eCommonBorderType_Progress then
    local max = data_var:get(packet.key.common_border_progress_max).v_int
    local progress = data_var:get(packet.key.common_border_progress).v_int
    border_table[id].max = max
    border_table[id].progress = progress
    local text_lens = data_var:get(packet.key.common_border_text_lens).v_int
    local progress_lens = data_var:get(packet.key.common_border_progress_lens).v_int
    local lens = text_lens + progress_lens
    if lens == 0 or lens == nil then
      lens = default_lens
    end
    cur_row.dx = lens
    main_lens = lens
  elseif item_type == bo2.eCommonBorderType_Timer then
    local max = data_var:get(packet.key.common_border_progress_max).v_int
    border_table[id].max = max
    border_table[id].progress = data_var:get(packet.key.common_border_progress).v_int
    local text_lens = data_var:get(packet.key.common_border_text_lens).v_int
    local progress_lens = data_var:get(packet.key.common_border_progress_lens).v_int
    local lens = text_lens + progress_lens
    if lens == 0 or lens == nil then
      lens = default_lens
    end
    cur_row.dx = lens
    main_lens = lens
  end
  if main_lens > max_lens then
    max_lens = main_lens
    w_main.dx = main_lens + 10
  end
  w_main.dy = 54 + 30 * w_list.item_count
  init_item(cur_row, item_type, id, data_var)
end
function init_item(item, item_type, id, data_var)
  if item == nil then
    return
  end
  if item_type == bo2.eCommonBorderType_Text then
    local text_id = data_var:get(packet.key.common_border_text).v_int
    local text_line = bo2.gv_text:find(text_id)
    if text_line then
      local value = sys.mtf_merge(data_var:get(packet.key.ui_text_arg), text_line.text)
      local label = item:search("text")
      label.text = value
    end
  elseif item_type == bo2.eCommonBorderType_Progress or item_type == bo2.eCommonBorderType_Timer then
    local max = border_table[id].max
    local progress = border_table[id].progress
    local text_lens = data_var:get(packet.key.common_border_text_lens).v_int
    local text_id = data_var:get(packet.key.common_border_text).v_int
    local text_line = bo2.gv_text:find(text_id)
    if text_line then
      local value = sys.mtf_merge(data_var:get(packet.key.ui_text_arg), text_line.text)
      local label = item:search("text")
      label.text = value
    end
    local label_panel = item:search("text_frm")
    label_panel.dx = text_lens
    local progress_lens = data_var:get(packet.key.common_border_progress_lens).v_int
    local progress_text
    if data_var:has(packet.key.org_begin) then
      progress_text = progress
    else
      progress_text = sys.format(L("%d/%d"), progress, max)
    end
    local progress_label = item:search("progress_text")
    progress_label.text = progress_text
    local frm = item:search("frm")
    local pic = item:search("pic_progress")
    frm.dx = progress_lens
    local dx = (frm.dx - 36) * (progress / max)
    if dx < 0 then
      dx = 0
    end
    pic.dx = dx
  end
  local is_have_fig = data_var:get(packet.key.common_border_have_fig).v_int
  if is_have_fig == 1 then
    local fig = item:search("high_light")
    fig.visible = false
  end
end
function remove(id)
  local item_data = border_table[id]
  if item_data == nil then
    return
  end
  local idx = item_data.idx
  if item_data ~= nil then
    w_list:item_remove(idx)
    for k, v in pairs(border_table) do
      if v ~= nil and idx < v.idx then
        v.idx = v.idx - 1
      end
    end
    border_table[id] = nil
  end
  w_main.dy = 54 + 30 * w_list.item_count
end
function update(data_var)
  if data_var == nil then
    return
  end
  local id = data_var:get(packet.key.common_border_id).v_int
  local item_data = border_table[id]
  if item_data == nil then
    return
  end
  local item = item_data.item
  local item_type = item_data.type
  if item_type == bo2.eCommonBorderType_Text then
    local text_id = data_var:get(packet.key.common_border_text).v_int
    local text_line = bo2.gv_text:find(text_id)
    if text_line then
      local value = sys.mtf_merge(data_var:get(packet.key.ui_text_arg), text_line.text)
      local label = item:search("text")
      label.text = value
    end
  elseif item_type == bo2.eCommonBorderType_Progress then
    local progress_chg = data_var:get(packet.key.common_border_progress_update).v_int
    local max = border_table[id].max
    local progress = border_table[id].progress + progress_chg
    if max < progress then
      progress = max
    end
    border_table[id].progress = progress
    local text_id = data_var:get(packet.key.common_border_text).v_int
    local text_line = bo2.gv_text:find(text_id)
    if text_line then
      local value = sys.mtf_merge(data_var:get(packet.key.ui_text_arg), text_line.text)
      local label = item:search("text")
      label.text = value
    end
    local label_panel = item:search("text_frm")
    local progress_text = progress .. "/" .. max
    local progress_label = item:search("progress_text")
    progress_label.text = progress_text
    local frm = item:search("frm")
    local pic = item:search("pic_progress")
    local dx = (frm.dx - 36) * (progress / max)
    if dx < 0 then
      dx = 0
    end
    pic.dx = dx
  end
end
function reset()
  max_lens = 0
  border_table = {}
  w_list:item_clear()
end
function visible(data_var)
  local is_visible = data_var:get(packet.key.common_border_visible).v_int
  if is_visible == 1 then
    w_main.visible = true
  else
    w_main.visible = false
  end
end
function on_init()
  reset()
end
function rebuild(data)
  for i = 0, data.size - 1 do
    local item = data:get(i)
    insert_item(item)
  end
end
function handle_visible(cmd, data)
  visible(data)
  if data:has(L("info")) then
    rebuild(data:get(L("info")))
  end
end
function handle_insert(cmd, data)
  insert_item(data)
end
function handle_update(cmd, data)
  update(data)
end
function handle_remove(cmd, data)
  local id = data:get(packet.key.common_border_id).v_int
  remove(id)
end
function handle_reset(cmd, data_var)
  if data_var:has(packet.key.cmn_system_flag) then
    local id = data_var:get(packet.key.common_border_id).v_int
    local item_data = border_table[id]
    if item_data == nil then
      return
    end
    if item_data.type ~= bo2.eCommonBorderType_Progress then
      return
    end
    local item = item_data.item
    local max = border_table[id].max
    local progress = 0
    border_table[id].progress = progress
    local text_id = data_var:get(packet.key.common_border_text).v_int
    local text_line = bo2.gv_text:find(text_id)
    if text_line then
      local value = sys.mtf_merge(data_var:get(packet.key.ui_text_arg), text_line.text)
      local label = item:search("text")
      label.text = value
    end
    if data_var:has(packet.key.common_border_progress) then
      local progress_label = item:search("progress_text")
      progress_label.text = data_var:get(packet.key.common_border_progress).v_string
    else
      local progress_text = progress .. "/" .. max
      local progress_label = item:search("progress_text")
      progress_label.text = progress_text
    end
    local frm = item:search("frm")
    local pic = item:search("pic_progress")
    local dx = (frm.dx - 36) * (progress / max)
    if dx < 0 then
      dx = 0
    end
    pic.dx = dx
  else
    reset()
  end
end
function on_visible(ctl, vis)
  gx_timer = not vis
end
function on_timer()
  if w_list.item_count == 0 then
    return
  end
  local remove_t = {}
  for i, v in pairs(border_table) do
    if v.type == bo2.eCommonBorderType_Timer then
      local max = v.max
      v.progress = v.progress - 1
      if 0 >= v.progress then
        table.insert(remove_t, i)
      else
        local item = v.item
        local label_panel = item:search("text_frm")
        local progress_text = v.progress .. "/" .. max
        local progress_label = item:search("progress_text")
        progress_label.text = progress_text
        local frm = item:search("frm")
        local pic = item:search("pic_progress")
        local dx = (frm.dx - 36) * (v.progress / max)
        if dx < 0 then
          dx = 0
        end
        pic.dx = dx
      end
    end
  end
  for i, v in pairs(remove_t) do
    remove(v)
  end
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_common_border.packet_handle"
reg(packet.eSTC_UI_CommonBorder_Visible, handle_visible, sig)
reg(packet.eSTC_UI_CommonBorder_Insert, handle_insert, sig)
reg(packet.eSTC_UI_CommonBorder_Update, handle_update, sig)
reg(packet.eSTC_UI_CommonBorder_Remove, handle_remove, sig)
reg(packet.eSTC_UI_CommonBorder_Reset, handle_reset, sig)
function handle_cmn_ask_win(cmd, data)
  if data:get(packet.key.ui_window_type).v_string ~= L("cmn_ask_player") then
    return
  end
  local text_id = data:get(packet.key.ui_text).v_int
  local time_out = data:get(packet.key.cmn_dataobj).v_int
  local function on_callback(callback_data)
    data:set(packet.key.cmn_rst, callback_data.result)
    bo2.send_variant(packet.eCTS_CmnAskWin_ReplyAsk, data)
  end
  local msg = {
    text = sys.mtf_merge(data:get(packet.key.ui_text_arg), bo2.gv_text:find(text_id).text),
    modal = true,
    btn_confirm = 1,
    btn_cancel = 1,
    callback = on_callback,
    timeout = time_out * 1000
  }
  ui_widget.ui_msg_box.show_common(msg)
end
reg(packet.eSTC_UI_OpenWindow, handle_cmn_ask_win, sig)
