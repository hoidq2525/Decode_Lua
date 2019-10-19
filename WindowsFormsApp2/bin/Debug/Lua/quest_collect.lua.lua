local reg = ui_packet.game_recv_signal_insert
local sig = "ui_npcfunc.ui_quest_collect.packet_handler"
local g_up_res_num = 0
local g_up_res_max = 0
local g_build_type = 0
local g_iscomplete = true
function add_item(cur_num, excel_id, max_count, quest_id, quest_opt)
  if excel_id == 0 then
    return
  end
  local item = g_res_list:item_append()
  item:load_style("$frame/quest/quest_collect.xml", "resitem")
  local excel = ui.item_get_excel(excel_id)
  if excel == nil then
    return
  end
  local res_name = excel.name
  item:search("res_name").mtf = res_name
  local arg = sys.variant()
  arg:set("cur_num", cur_num)
  arg:set("max_num", max_count)
  local res_count = ""
  res_count = sys.mtf_merge(arg, ui.get_text("org|res_count_mtf"))
  item:search("res_count").mtf = res_count
  item.svar.excel_id = excel_id
  item.svar.max_count = max_count
  item.svar.cur_num = cur_num
  item.svar.quest_id = quest_id
  item.svar.quest_opt = quest_opt
  return max_count <= cur_num
end
function set_build_info(data)
  local quest_id = data:get(packet.key.quest_id).v_int
  local quest_opt = data:get(packet.key.quest_opt).v_int
  local quest_comp = data:get(packet.key.quest_comp).v_int
  local quest_info = ui.quest_find(quest_id)
  if quest_info == nil then
    quest_info = ui.guild_quest_find(quest_id)
    if quest_info == nil then
      return
    end
  end
  local list = quest_info.excel
  local cur_num = quest_comp
  add_item(cur_num, list.req_id[quest_opt], list.req_max[quest_opt], quest_id, quest_opt)
end
function on_build_res_visible(w, vis)
  if vis then
  else
  end
  g_res_list:item_clear()
end
function on_init(win)
end
function on_update(quest_info)
  local excel = quest_info.excel
  if quest_info.completed then
    w_build_res.visible = false
    return
  end
  g_res_list:item_clear()
  if excel.req_obj[0] ~= bo2.eQuestObj_NpcCollect then
    return
  end
  for i = 1, 3 do
    local cur_num = quest_info.comp[i]
    local req_id = excel.req_id[i]
    local req_max = excel.req_max[i]
    local quest_id = excel.id
    local quest_opt = i
    add_item(cur_num, req_id, req_max, quest_id, quest_opt)
  end
end
function close_win()
  w_build_res.visible = false
  if res_send ~= nil then
    res_send.visible = false
  end
end
function on_item_btnclick(btn)
  local item = btn.parent
  local des_text = ""
  local excel_id = item.svar.excel_id
  local cur_num = item.svar.cur_num
  local max_count = item.svar.max_count
  local quest_id = item.svar.quest_id
  local quest_opt = item.svar.quest_opt
  local arg = sys.variant()
  arg:set("group", 1)
  des_text = sys.mtf_merge(arg, ui.get_text("org|res_des_item"))
  local function send_to_server(item)
    local res_num = g_up_res_num
    if res_num < 0 then
      return
    end
    if res_num > g_up_res_max then
      res_num = g_up_res_max
    end
    local v = sys.variant()
    v:set(packet.key.quest_id, item.svar.quest_id)
    v:set(packet.key.quest_opt, item.svar.quest_opt)
    v:set(packet.key.quest_comp, res_num)
    v:set(packet.key.cmn_id, excel_id)
    bo2.send_variant(packet.eCTS_UI_Add_Quest_Comp, v)
  end
  local function init_res_num()
    local in_bag_num = ui.item_get_count(excel_id, true)
    if in_bag_num > max_count - cur_num then
      g_up_res_max = max_count - cur_num
    else
      g_up_res_max = in_bag_num
    end
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = "$frame/quest/quest_collect.xml",
    style_name = "res_send",
    init = function(data)
      data.window:search("res_send_des").text = des_text
      init_res_num()
      w_input.text = 0
    end,
    callback = function(ret)
      if ret.result == 1 then
        local res_name = ""
        local group_num = 1
        local text_name = "org|res_send_des_sure1"
        g_up_res_num = tonumber(tostring(w_input.text))
        if g_up_res_num <= 0 then
          ui_chat.show_ui_text_id(1875)
          return
        end
        if g_up_res_num > g_up_res_max then
          g_up_res_num = g_up_res_max
        end
        if g_up_res_num <= 0 then
          ui_chat.show_ui_text_id(1875)
          return
        end
        local excel = ui.item_get_excel(excel_id)
        local res_name = excel.name
        text_name = "org|res_send_des_sure3"
        local arg = sys.variant()
        arg:set("num", g_up_res_num)
        arg:set("res_name", res_name)
        local msg = {
          text = sys.mtf_merge(arg, ui.get_text(text_name)),
          modal = true,
          btn_confirm = 1,
          btn_cancel = 1,
          callback = function(data)
            if data.result == 1 then
              send_to_server(item)
            end
          end
        }
        ui_widget.ui_msg_box.show_common(msg)
      end
    end
  })
end
function on_stepping_head()
  g_up_res_num = tonumber(tostring(w_input.text))
  if g_up_res_num == 0 then
    return
  end
  g_up_res_num = 0
  w_input.text = g_up_res_num
end
function on_stepping_prev()
  g_up_res_num = tonumber(tostring(w_input.text))
  if g_up_res_num == 0 then
    return
  end
  if g_up_res_num > g_up_res_max then
    g_up_res_num = g_up_res_max
  else
    g_up_res_num = g_up_res_num - 1
  end
  w_input.text = g_up_res_num
end
function on_stepping_foot()
  g_up_res_num = tonumber(tostring(w_input.text))
  if g_up_res_num == g_up_res_max then
    return
  end
  g_up_res_num = g_up_res_max
  w_input.text = g_up_res_num
end
function on_stepping_next()
  g_up_res_num = tonumber(tostring(w_input.text))
  if g_up_res_num == g_up_res_max then
    return
  end
  if g_up_res_num > g_up_res_max then
    g_up_res_num = g_up_res_max
  else
    g_up_res_num = g_up_res_num + 1
  end
  w_input.text = g_up_res_num
end
function on_collect_window(cmd, data)
  w_build_res.visible = true
  set_build_info(data)
end
local sig_name = "ui_quest.ui_quest_collect:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_OpenColWin, on_collect_window, sig_name)
