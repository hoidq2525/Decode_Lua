local m_ridepet_page_current = 0
local m_ridepet_page_count = 7
local step_ctrl, kill_ridepet, target_ridepet, w_zhenyan
local g_zhenjiao = {}
function on_init_zhenjiao(ctrl, data)
  local slot = data.v_int
  g_zhenjiao[slot] = {
    lock = ctrl:search("big_lock"),
    bg = ctrl:search("big_bg")
  }
end
function clear_all()
  w_zhenyan.grid = -1
end
function clear_kill_ridepet()
  kill_ridepet = nil
end
function update_zhenfa()
  w_zhenyan.grid = target_ridepet:get_flag(bo2.eRidePetFlagInt32_Pos)
  local zhenfa_count = target_ridepet:get_flag(bo2.eRidePetFlagInt32_ZhenFa)
  for i = 2, 9 do
    if i <= zhenfa_count then
      g_zhenjiao[i - 1].lock.visible = false
      g_zhenjiao[i - 1].bg.visible = true
    else
      g_zhenjiao[i - 1].lock.visible = true
      g_zhenjiao[i - 1].bg.visible = false
    end
  end
end
function on_btn_ok(ctrl)
  if kill_ridepet == nil then
    ui_chat.show_ui_text_id(2684)
    return
  else
    if not check_kill_ridepet(target_ridepet, kill_ridepet) then
      return
    end
    do
      local zhenfa_count = target_ridepet:get_flag(bo2.eRidePetFlagInt32_ZhenFa)
      if zhenfa_count >= 9 then
        ui_chat.show_ui_text_id(2691)
        return
      end
      local nums = bo2.gv_define:find(1284)
      if nums == nil then
        return
      end
      local nums_vec = ui_ridepet.GetVecFromString(nums.value)
      zhenfa_count = zhenfa_count + 1
      local kill_count = kill_ridepet:get_flag(bo2.eRidePetFlagInt32_ZhenFa)
      if ui_ridepet.get_ridepet_jipo_state(kill_ridepet) then
        ui_chat.show_ui_text_id(2696)
        return
      end
      if ui_ridepet.get_ridepet_jipo_state(target_ridepet) then
        ui_chat.show_ui_text_id(2697)
        return
      end
      if kill_count > 0 then
        ui_widget.ui_msg_box.show_common({
          text = ui.get_text("pet|ridepet_kill_ridepet"),
          modal = true,
          btn_confirm = true,
          btn_cancel = true,
          callback = function(msg)
            if msg.result == 1 then
              ui_widget.ui_msg_box.show_common({
                text = ui_widget.merge_mtf({
                  num = nums_vec[zhenfa_count + 1]
                }, ui.get_text("pet|ridepet_openzhenjiao")),
                modal = true,
                btn_confirm = true,
                btn_cancel = true,
                callback = function(msg)
                  if msg.result == 1 then
                    ui_ridepet.send_open_zhenjiao(target_ridepet.onlyid, kill_ridepet.onlyid)
                  end
                end
              })
            else
              return
            end
          end
        })
      else
        ui_widget.ui_msg_box.show_common({
          text = ui_widget.merge_mtf({
            num = nums_vec[zhenfa_count + 1]
          }, ui.get_text("pet|ridepet_openzhenjiao")),
          modal = true,
          btn_confirm = true,
          btn_cancel = true,
          callback = function(msg)
            if msg.result == 1 then
              ui_ridepet.send_open_zhenjiao(target_ridepet.onlyid, kill_ridepet.onlyid)
            end
          end
        })
      end
    end
  end
end
function check_kill_ridepet(zhenyan_info, zhenjiao_info)
  local lock = zhenjiao_info:get_flag(bo2.eRidePetFlagInt32_SafeFrozen)
  if lock > 0 then
    ui_chat.show_ui_text_id(2693)
    return false
  end
  if zhenyan_info.onlyid == zhenjiao_info.onlyid then
    ui_chat.show_ui_text_id(2685)
    return false
  end
  local zhenyan_potential = zhenyan_info:get_flag(bo2.eRidePetFlagInt32_Potential)
  local zhenjiao_potential = zhenjiao_info:get_flag(bo2.eRidePetFlagInt32_Potential)
  if zhenyan_potential > zhenjiao_potential then
    ui_chat.show_ui_text_id(2686)
    return false
  end
  local zhenyan_natural_vit = zhenyan_info:get_flag(bo2.eRidePetFlagInt32_NaturalVit)
  local zhenjiao_natural_vit = zhenjiao_info:get_flag(bo2.eRidePetFlagInt32_NaturalVit)
  if zhenyan_natural_vit > zhenjiao_natural_vit then
    ui_chat.show_ui_text_id(2687)
    return false
  end
  local zhenyan_natural_agi = zhenyan_info:get_flag(bo2.eRidePetFlagInt32_NaturalAgi)
  local zhenjiao_natural_agi = zhenjiao_info:get_flag(bo2.eRidePetFlagInt32_NaturalAgi)
  if zhenyan_natural_agi > zhenjiao_natural_agi then
    ui_chat.show_ui_text_id(2688)
    return false
  end
  local zhenyan_natural_str = zhenyan_info:get_flag(bo2.eRidePetFlagInt32_NaturalStr)
  local zhenjiao_natural_str = zhenjiao_info:get_flag(bo2.eRidePetFlagInt32_NaturalStr)
  if zhenyan_natural_str > zhenjiao_natural_str then
    ui_chat.show_ui_text_id(2689)
    return false
  end
  local zhenyan_natural_int = zhenyan_info:get_flag(bo2.eRidePetFlagInt32_NaturalInt)
  local zhenjiao_natural_int = zhenjiao_info:get_flag(bo2.eRidePetFlagInt32_NaturalInt)
  if zhenyan_natural_int > zhenjiao_natural_int then
    ui_chat.show_ui_text_id(2690)
    return false
  end
  return true
end
function on_ride_card_mouse(card, msg, pos, wheel)
  if card.info == nil then
    return
  end
  if msg == ui.mouse_lbutton_click then
    if ui.is_key_down(ui.VK_CONTROL) then
      ui_chat.insert_ridepet(ui.ride_encode(card.info))
    else
      local pos = card.grid
      select_ridepet(pos)
    end
    return
  end
end
function select_ridepet(pos)
  local info = ui_ridepet.find_info_from_pos(pos)
  if info ~= nil then
    update_ridepet(info)
  else
    clear_ui()
    ui.ride_set_select(-1)
  end
end
function update_ridepet(info)
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      if ctr:search("ridepet").grid == info.grid then
        kill_ridepet = info
        ctr:search("select").visible = true
      else
        ctr:search("select").visible = false
      end
    end
  end
end
function on_ridepet_tip(tip)
  local stk = sys.mtf_stack()
  local card = tip.owner
  if card.info == nil then
    local text = ui.get_text("pet|ridepet_name")
    stk:push(text)
    ui_tool.ctip_show(card, stk)
    return
  end
  ctip_make_ridepet(stk, card.info)
  ui_tool.ctip_show_custom(card, stk, 200)
end
function ctip_make_ridepet(stk, info)
  ui_ridepet.build_ridepet_tip(stk, info)
  ui_tool.ctip_push_sep(stk)
  if info.box == bo2.eRidePetBox_Slot then
    local txt = ui_ridepet.use_tip(info)
    if txt ~= nil then
      stk:raw_push(SHARED("\n"))
      ui_tool.ctip_push_text(stk, txt, ui_tool.cs_tip_color_operation)
    end
  end
end
function on_page_step(var)
  update_page(var.index)
end
function update_page(page)
  ui_widget.ui_stepping.set_page(step_ctrl, page, m_ridepet_page_count)
  set_ridepet_page(page)
end
function set_ridepet_page(page)
  if kill_ridepet == nil and target_ridepet == nil then
    return
  end
  if kill_ridepet == nil then
    kill_ridepet = target_ridepet
  end
  local info = ui_ridepet.find_info_from_pos(kill_ridepet.grid)
  if info == nil then
    return
  end
  m_ridepet_page_current = page
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      ctr:search("ridepet").grid = page + i
    end
  end
  update_ridepet(info)
end
function on_init(ctrl)
  local parent = w_main:search(L("ridepet_list"))
  step_ctrl = parent:search(L("step"))
  ui_widget.ui_stepping.set_event(step_ctrl, on_page_step)
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      ctr:search("ridepet").grid = i
    end
  end
  kill_ridepet = nil
  target_ridepet = nil
  update_page(m_ridepet_page_current)
  local p_zhenyan = w_main:search(L("zhenyan"))
  w_zhenyan = p_zhenyan:search(L("ridepet"))
end
function on_visible(w, vis)
  if vis == false then
    clear_all()
  end
  ui_widget.on_esc_stk_visible(w, vis)
  target_ridepet = ui_ridepet.find_info_from_pos(ui.ride_get_select())
  if target_ridepet == nil then
    return
  end
  kill_ridepet = target_ridepet
  update_zhenfa()
  update_ridepet(kill_ridepet)
end
